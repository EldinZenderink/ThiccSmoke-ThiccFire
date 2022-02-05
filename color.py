import argparse
parser = argparse.ArgumentParser()
parser.add_argument("rgb", help="Provide comma seperated rgb values (e.g. 255,255,255 (r,g,b) or 255,255,255,255 (r,g,b,a))")
args = parser.parse_args()

if args.rgb:
    colors = args.rgb.split(',')
    if len(colors) < 3:
        exit(f"Did not provide colors in rgb comma seperated (e.g. 255,255,255 (r,g,b) or 255,255,255,255 (r,g,b,a)), provided: {args.rgb}")
    converted = [round((int(colors[0]) / 255), 2), round((int(colors[1]) / 255), 2), round((int(colors[2]) / 255), 2)]
    if len(colors) == 4:
        converted = [round((int(colors[0]) / 255), 2), round((int(colors[1]) / 255), 2), round((int(colors[2]) / 255), 2),  round((int(colors[3]) / 255), 2)]
        print(f"Converted:")
        print("{" + f"r={converted[0]},g={converted[1]},b={converted[2]},a={converted[3]}" + "}")
    else:
        print(f"Converted:")
        print("{" + f"r={converted[0]},g={converted[1]},b={converted[2]},a=1" + "}")
else:
    exit("Did not provide colors in rgb comma seperated (e.g. 255,255,255 (r,g,b) or 255,255,255,255 (r,g,b,a))")