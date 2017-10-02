// fetch the data from the API
$(document).ready(function(){
  setInterval(function() {
    axios.get('/api/last_five_minutes', { params: {} })
      .then(function(response) {
        processData(response.data);
      })
      .catch(function(error) {
        // can't fetch data - display some type of error page
        console.log(error);
      });
  }, 2000);
});

// update the page
function processData(data) {
  data.forEach(function(site) { showSite(site) });
}

// write the shit to the thing
function showSite(site) {
  if ($("tr." + site["date"]).length > 0) {
    updateRow(site)
  } else {
    createRow(site)
  }
}

function updateRow(site) {
  console.log("updating row");
  var td = $("<td>" + site["bitmap"] + "</td><td>" + site["site"] + "</td>");
  $("div#app table tbody tr." + site["date"]).html(td)
}

function createRow(site) {
  console.log("creating row");
  var td = $("<td>" + site["bitmap"] + "</td><td>" + site["site"] + "</td>");
  var tr = $("<tr></tr>");
  tr.attr("class", site["date"])
  tr.append(td)
  $("div#app table tbody").append(tr)
}

// bitmap should be stylised

// stylize bitmap

// * 

