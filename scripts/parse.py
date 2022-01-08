import json, sys

input = json.loads(sys.stdin.read())

if len(sys.argv) == 3 and len(sys.argv[2]) > 0:
  print(input[sys.argv[2]][sys.argv[1]])
else:
  print(input[sys.argv[1]])

