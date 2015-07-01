 // (function() {
  var wefio = {};
  wefio.files = function(dir){
  return jsc_files(dir);
  // return [{"name":"test1", "size":1234, "attributes":755, "type":"image/png"}];
  };

  // return wefio;
// })()

function reloadView(files){
  document.getElementById("files").innerHTML = files[0].name;
}
