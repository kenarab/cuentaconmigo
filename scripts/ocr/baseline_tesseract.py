#!/usr/bin/env python3
"""Baseline: share of transcribed values (data/ocr-samples) found among the numbers
Tesseract detects on each page (the same help the app shows as chips).
Provisional: cells are not human-confirmed yet. Small numbers (0, 1) may match by chance.
Needs the PDFs in data/private/ocr-samples (scripts/samples/fetch_ocr_samples.py),
pdftoppm and tesseract with the spa language."""
import csv, re, subprocess, sys, tempfile, collections
from pathlib import Path
root=Path(".")
vals=collections.defaultdict(list)
with open("data/ocr-samples/planilla-valores.csv",encoding="utf-8-sig",newline="") as f:
  for r in csv.DictReader(f,delimiter=";"):
    if r["valor"].strip().isdigit(): vals[(r["archivo"],int(r["pagina"] or 1))].append(int(r["valor"]))
tot=hit=0; per={}
for (arch,pg),vs in sorted(vals.items()):
  pdf=Path("data/private/ocr-samples")/arch
  if not pdf.exists(): continue
  with tempfile.TemporaryDirectory() as t:
    subprocess.run(["pdftoppm","-r","300","-f",str(pg),"-l",str(pg),"-singlefile","-png",str(pdf),f"{t}/p"],check=True)
    out=""
    for psm in ("11","6"):
      out+=subprocess.run(["tesseract",f"{t}/p.png","-","--psm",psm,"-l","spa"],capture_output=True,text=True).stdout
  found=set(int(x) for x in re.findall(r"\d+",out) if len(x)<=4)
  h=sum(v in found for v in vs); tot+=len(vs); hit+=h; per[arch]=(h,len(vs))
for a,(h,n) in per.items(): print(f"{a}: {h}/{n}")
print(f"TOTAL recall de valores entre números detectados: {hit}/{tot} = {100*hit/tot:.1f}%")
