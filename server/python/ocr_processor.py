#!/usr/bin/env python3
"""
GEAMH HRIS — AI Scanning Tool Python OCR Processor
Integrates with PHP backend for document scanning and OCR processing.

Requirements:
  pip install pytesseract pillow pdf2image pandas python-docx

Tesseract must be installed:
  Windows: https://github.com/UB-Mannheim/tesseract/wiki
  Default path: C:\\Program Files\\Tesseract-OCR\\tesseract.exe
"""

import sys
import json
import os
import re
from pathlib import Path

# ── Dependency check ──────────────────────────────────────────────────────────
missing = []
try:
    from PIL import Image, ImageFilter, ImageEnhance
except ImportError:
    missing.append('Pillow')

try:
    import pytesseract
except ImportError:
    missing.append('pytesseract')

if missing:
    print(json.dumps({
        'error': f'Missing Python libraries: {", ".join(missing)}. '
                 f'Run: pip install {" ".join(missing)}',
        'success': False
    }))
    sys.exit(1)

# ── Tesseract path configuration ──────────────────────────────────────────────
TESSERACT_PATHS = [
    r'C:\Program Files\Tesseract-OCR\tesseract.exe',
    r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
    r'C:\Users\{}\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'.format(
        os.environ.get('USERNAME', 'user')
    ),
    '/usr/bin/tesseract',
    '/usr/local/bin/tesseract',
]

for path in TESSERACT_PATHS:
    if os.path.exists(path):
        pytesseract.pytesseract.tesseract_cmd = path
        break


def preprocess_image(image_path: str) -> Image.Image:
    """Preprocess image for better OCR accuracy."""
    img = Image.open(image_path)

    # Convert to RGB if needed
    if img.mode not in ('RGB', 'L'):
        img = img.convert('RGB')

    # Upscale small images
    w, h = img.size
    if max(w, h) < 2000:
        scale = 2000 / max(w, h)
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)

    # Convert to grayscale
    img = img.convert('L')

    # Enhance contrast
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(2.0)

    # Sharpen
    img = img.filter(ImageFilter.SHARPEN)

    return img


def process_image(image_path: str) -> dict:
    """Process image files using Tesseract OCR."""
    try:
        img = preprocess_image(image_path)

        # OCR with page segmentation mode 6 (uniform block of text)
        # and OEM 3 (default, based on what is available)
        custom_config = r'--oem 3 --psm 6'
        text = pytesseract.image_to_string(img, config=custom_config)

        # Get confidence score
        data = pytesseract.image_to_data(img, config=custom_config,
                                          output_type=pytesseract.Output.DICT)
        confidences = [int(c) for c in data.get('conf', []) if str(c) != '-1' and int(c) >= 0]
        confidence = round(sum(confidences) / len(confidences), 2) if confidences else 0

        return {
            'text': text.strip(),
            'confidence': confidence,
            'success': True
        }
    except Exception as e:
        return {'error': str(e), 'success': False}


def process_pdf(pdf_path: str) -> dict:
    """Process PDF files using pdf2image and Tesseract."""
    try:
        import pdf2image
    except ImportError:
        return {
            'error': 'pdf2image not installed. Run: pip install pdf2image',
            'success': False
        }

    try:
        images = pdf2image.convert_from_path(pdf_path, dpi=200)
        all_text = []
        total_confidence = 0

        for i, image in enumerate(images):
            # Convert to grayscale and enhance
            img = image.convert('L')
            enhancer = ImageEnhance.Contrast(img)
            img = enhancer.enhance(1.8)

            custom_config = r'--oem 3 --psm 6'
            text = pytesseract.image_to_string(img, config=custom_config)
            data = pytesseract.image_to_data(img, config=custom_config,
                                              output_type=pytesseract.Output.DICT)

            confidences = [int(c) for c in data.get('conf', [])
                           if str(c) != '-1' and int(c) >= 0]
            page_conf = sum(confidences) / len(confidences) if confidences else 0

            all_text.append(f'--- Page {i + 1} ---\n{text.strip()}')
            total_confidence += page_conf

        avg_confidence = total_confidence / len(images) if images else 0

        return {
            'text': '\n\n'.join(all_text),
            'confidence': round(avg_confidence, 2),
            'pages': len(images),
            'success': True
        }
    except Exception as e:
        return {'error': str(e), 'success': False}


def process_spreadsheet(file_path: str) -> dict:
    """Process Excel/CSV files using pandas."""
    try:
        import pandas as pd
    except ImportError:
        return {
            'error': 'pandas not installed. Run: pip install pandas openpyxl',
            'success': False
        }

    try:
        if file_path.endswith('.csv'):
            df = pd.read_csv(file_path)
        else:
            df = pd.read_excel(file_path)

        text = df.to_string(index=False)

        return {
            'text': text,
            'confidence': 95.0,
            'rows': len(df),
            'columns': len(df.columns),
            'success': True
        }
    except Exception as e:
        return {'error': str(e), 'success': False}


def process_docx(file_path: str) -> dict:
    """Process Word documents using python-docx."""
    try:
        from docx import Document
    except ImportError:
        return {
            'error': 'python-docx not installed. Run: pip install python-docx',
            'success': False
        }

    try:
        doc = Document(file_path)
        paragraphs = [para.text for para in doc.paragraphs if para.text.strip()]
        text = '\n'.join(paragraphs)

        return {
            'text': text,
            'confidence': 90.0,
            'paragraphs': len(paragraphs),
            'success': True
        }
    except Exception as e:
        return {'error': str(e), 'success': False}


def check_tesseract() -> bool:
    """Verify Tesseract is accessible."""
    try:
        version = pytesseract.get_tesseract_version()
        return True
    except Exception:
        return False


def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            'error': 'Usage: python ocr_processor.py <file_path>',
            'success': False
        }))
        sys.exit(1)

    file_path = sys.argv[1]

    if not os.path.exists(file_path):
        print(json.dumps({
            'error': f'File not found: {file_path}',
            'success': False
        }))
        sys.exit(1)

    ext = Path(file_path).suffix.lower()
    result = {}

    try:
        if ext in ('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'):
            if not check_tesseract():
                print(json.dumps({
                    'error': 'Tesseract OCR not found. Install from: '
                             'https://github.com/UB-Mannheim/tesseract/wiki',
                    'success': False
                }))
                sys.exit(1)
            result = process_image(file_path)

        elif ext == '.pdf':
            result = process_pdf(file_path)

        elif ext in ('.xlsx', '.xls', '.csv'):
            result = process_spreadsheet(file_path)

        elif ext in ('.docx', '.doc'):
            result = process_docx(file_path)

        else:
            result = {
                'error': f'Unsupported file type: {ext}',
                'success': False
            }

    except Exception as e:
        result = {'error': str(e), 'success': False}

    # Always output valid JSON on the last line
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0 if result.get('success') else 1)


if __name__ == '__main__':
    main()
