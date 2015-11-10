
// Steps:
  // Go to http://edmunds.mashery.com/io-docs and log in
    // Under "Get all car makes", enter "new" and "2016" or any year that you'd like to update
    // Copy JSON response object and paste it into this document and set it on the vehicleObject variable
  // Copy current vehicleList from resources/json/vehicleList.js and set it on the vehicleList varible
  // Pass the variables into the function along with the year you searched for
  // Copy the result and replace the resources/json/vehicleList.js contents with what it returns


var updateVehicleList = function(vehicleList, vehicleObject, year){
  vehicleList[year] = {};
  for (var i = 0; i < vehicleObject.makesCount; i++){
    vehicleList[year][vehicleObject.makes[i].name] = [];
    for (var x = 0; x < vehicleObject.makes[i].models.length; x++){
      vehicleList[year][vehicleObject.makes[i].name].push(vehicleObject.makes[i].models[x].name);
    }
  }
  return vehicleList;
}