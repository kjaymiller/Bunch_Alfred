import json
import subprocess

cmd=subprocess.run(['ruby', './bunch.rb', '-l'], capture_output=True)
items=cmd.stdout.decode('utf-8')

def make_json_path(p):
    return {
        "title": p,
        "subtitle": "run the {} Bunch".format(p),
        "arg": p,
        }

json_item = {}
json_item['items']=list(map(make_json_path, items.split('\n')))
print(json.dumps(json_item))
