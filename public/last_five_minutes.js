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
  }, 1000);
});

// update the page
function processData(data) {
  data.forEach(function(site) { showSite(site) });
}

// write the shit to the thing
function showSite(site) {
  const up_symbol   = "❤"
  const down_symbol = "🔥"

  const last_state = site["bitmap"][site["bitmap"].length - 1];

  site["state"] = last_state == 1 ? up_symbol : down_symbol;

  const good_symbol = "✓"
  const bad_symbol  = "✗"

  site["bitmap"] = site["bitmap"].replace(/1/g, good_symbol).replace(/0/g, bad_symbol);

  console.log("tr." + site["date"] + "#" + site["site"])

  if ($("tr." + site["date"] + "#" + site["site"]).length > 0) {
    console.log("update row")
    updateRow(site)
  } else {
    console.log("create row")
    createRow(site)
  }
}

function updateRow(site) {
  var td = $("<td class='state'>" + site["state"] + "</td><td class='bitmap'>" + site["bitmap"] + "</td><td class='site'>" + site["site"] + "</td>");
  $("div#app table tbody tr#" + site["site"] + "." + site["date"]).html(td)
}

function createRow(site) {
  var td = $("<td class='state'>" + site["state"] + "</td><td class='bitmap'>" + site["bitmap"] + "</td><td class='site'>" + site["site"] + "</td>");
  var tr = $("<tr></tr>");
  tr.attr("class", site["date"])
  tr.attr("id", site["site"])
  tr.append(td)
  $("div#app table tbody").append(tr)
}

// bitmap should be stylised
