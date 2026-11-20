import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
import pdfplumber

for name in ['Yuhao Huang_CV.pdf', 'WINAMAX - Book de stages 2027 (2).pdf']:
    path = r'd:\软件工程\L2 第二學期\Innovation project\\' + name
    print(f'\n\n########## {name} ##########')
    with pdfplumber.open(path) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                print(f'\n--- PAGE {i+1} ---')
                print(text)
