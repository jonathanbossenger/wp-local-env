import json

file = open('wp-local-env.json')
data = json.load(file)
print(data['info']['wp-local-env']['ipv4'][0])