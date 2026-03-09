import sys
try:
    from pypdf import PdfReader
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pypdf"])
    from pypdf import PdfReader

try:
    reader = PdfReader(r"c:\company college projects\senior_care_connect\product_backlog_ROLE_BASED_FINAL (1).pdf")
    text = "\n".join([page.extract_text() for page in reader.pages])
    with open(r"extract_pdf_out.txt", "w", encoding="utf-8") as f:
        f.write(text)
    print("Success")
except Exception as e:
    print(f"Error: {e}")
