import json

logs = []
with open("logs.json", "r", encoding="UTF-8") as f:
	content = json.loads(f.read())
	if type(content) == list:
		for log in content:
			print(("[DEBUG] " if log['type'] == "message" else "[DEBUG ERROR] ") + str(log['content']))
	elif type(content) == dict:
		print("CLIENT LOGS:")
		for log in content['client']:
			print(("[DEBUG] " if log['type'] == "message" else "[DEBUG ERROR] ") + str(log['content']))
		print("\nSERVER LOGS:")
		for log in content['server']:
			print(("[DEBUG] " if log['type'] == "message" else "[DEBUG ERROR] ") + str(log['content']))
	else:
		raise ValueError("Wrong logs format")