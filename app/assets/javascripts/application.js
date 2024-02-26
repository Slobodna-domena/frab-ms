document.addEventListener("DOMContentLoaded", function() {

  if (document.getElementById("student").checked){
    document.getElementById("document_div").style.display = 'block'
  } else {
    document.getElementById("document_div").style.display = 'none'
  }

  document.getElementById("student").addEventListener("change",function(){
    if (document.getElementById("student").checked){
      document.getElementById("document_div").style.display = 'block'
    } else {
      document.getElementById("document_div").style.display = 'none'
    }
  })



});
