import os, re
import argparse

# take in two files: one extracted header with HD, SQ, RG, PG lines, one template with just HD and SQ lines
# replace all HD and SQ lines with template, keep RG and PG lines, and write to new file

def getArgs():
    parser = argparse.ArgumentParser(description="Replace HD and SQ lines in header with template")
    parser.add_argument("--header", type=str, help="Header file with HD and SQ lines")
    parser.add_argument("--template", type=str, help="Template file with HD and SQ lines")
    parser.add_argument("--output", type=str, help="Output file")
    return parser.parse_args()

def main():
    args = getArgs()
    header = args.header
    template = args.template
    output = args.output

    with open(header, 'r') as h:
        header_lines = h.readlines()
    with open(template, 'r') as t:
        template_lines = t.readlines()

    with open(output, 'w') as o:
        for line in template_lines:
            o.write(line)
        for line in header_lines:
            if line.startswith("@HD") or line.startswith("@SQ"):
                continue
            else:
                o.write(line)

if __name__ == "__main__":
    main()
    