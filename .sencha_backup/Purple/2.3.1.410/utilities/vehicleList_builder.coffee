result = {}

for v in json
  if not result[v["Year"]]?
    result[v["Year"]] = {}
  if not result[v["Year"]][v["Make"]]?
    result[v["Year"]][v["Make"]] = []
  if result[v["Year"]][v["Make"]].indexOf(v["Model"]) is -1
    result[v["Year"]][v["Make"]].push v["Model"]

# console.log result["2003"]["Saturn"]


# the result of this is the vehicleList for app
document.write JSON.stringify(result)
