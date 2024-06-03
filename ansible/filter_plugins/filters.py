import json


def to_minified_json(file_path):
    with open(file_path, 'r') as f:
        content = json.load(f)
    return json.dumps(content, separators=(',', ':'))


class FilterModule(object):
    def filters(self):
        return {
            'to_minified_json': to_minified_json,
        }
