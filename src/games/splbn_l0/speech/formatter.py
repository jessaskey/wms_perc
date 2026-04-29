import sys
import os

def trim_cvsd_silence(data, min_run=8, silence_byte=0x55):
    silence = silence_byte

    # ----- trim leading noise + leading $55,$AA stream -----
    run = 0
    start_cut = None

    for i, b in enumerate(data):
        if b == silence:
            run += 1
            if run == min_run:
                start_cut = i - min_run + 1
                break
        else:
            run = 0

    if start_cut is not None:
        pos = start_cut
        while pos < len(data) and data[pos] == silence:
            pos += 1
        data = data[pos:]

    # ----- trim trailing $55 stream + anything after it -----
    run = 0
    end_cut = None

    for i, b in enumerate(data):
        if b == silence:
            run += 1
            if run == min_run:
                # Cut at the beginning of the first qualifying trailing/silence run
                end_cut = i - min_run + 1
                break
        else:
            run = 0

    if end_cut is not None:
        data = data[:end_cut]

    return data


def dump_hex_db(input_file, output_file):
    try:
        with open(input_file, "rb") as f:
            data = f.read()
    except Exception as e:
        print(f"Error opening input file: {e}")
        return

    # Trim noisy lead-in / lead-out based on $55 silence streams
    #data = trim_cvsd_silence(data, min_run=4, silence_byte=0x55)
    #data = trim_cvsd_silence(data, min_run=4, silence_byte=0xAA)

    bytes_per_line = 16

    try:   
        header = build_header(input_file)
        footer = build_footer(input_file)
        
        with open(output_file, "a") as out:    
            out.write(header + "\n")  
            
            for i in range(0, len(data), bytes_per_line):
                chunk = data[i:i + bytes_per_line]
                hex_bytes = [f"${b:02X}" for b in chunk]
                line = ".db " + ",".join(hex_bytes)
                out.write(line + "\n")
                
            out.write(footer + "\n")  

    except Exception as e:
        print(f"Error writing output file: {e}")
        return

    print(f"Output written to: {output_file}")

def build_header(input_file):
    base = os.path.basename(input_file)          # strip path
    name = os.path.splitext(base)[0]             # remove extension
    last_part = name.split("_")[-1]              # after last "_"
    return f"ut_{last_part.lower()}_beg"
    
def build_footer(input_file):
    base = os.path.basename(input_file)          # strip path
    name = os.path.splitext(base)[0]             # remove extension
    last_part = name.split("_")[-1]              # after last "_"
    return f"ut_{last_part.lower()}_end"

def main():
    if len(sys.argv) != 3:
        print("Usage: python dump_hex.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.isfile(input_file):
        print(f"Input file not found: {input_file}")
        sys.exit(1)

    dump_hex_db(input_file, output_file)


if __name__ == "__main__":
    main()