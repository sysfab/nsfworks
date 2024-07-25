import json

logs = []
with open("logs.json", "r", encoding="UTF-8") as f:
	for log in json.loads(f.read()):
		print(("[DEBUG] " if log['type'] == "message" else "[DEBUG ERROR] ") + str(log['content']))