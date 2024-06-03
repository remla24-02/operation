import json


def minify_json_string(json_string):
    res = json.loads(json_string)
    return json.dumps(res, separators=(',', ':'))


class FilterModule(object):
    def filters(self):
        return {
            'minify_json_string': minify_json_string,
        }
