require("selectize/");const queryString=require("query-string");document.addEventListener("DOMContentLoaded",function(){const e=window.location;$(".selectize").selectize({plugins:["remove_button"]}),tinymce.init({selector:".has_editor",plugins:["image link code paste lists advlist wordcount media help"],menubar:!1,height:300,toolbar:"undo redo | cut copy paste | bold italic | bullist numlist h2 h3 | link | image media | code help"}),tinymce.init({selector:".has_editor_minimal",plugins:["lists wordcount textcolor"],menubar:!1,height:300,toolbar:"bold italic | numlist | forecolor backcolor"});var t={};if(document.querySelector("#searchSettings")){document.getElementById("searchSettings").addEventListener("click",function(){document.querySelector(".selectorTool").classList.toggle("open")});const t=document.querySelectorAll(".selectorTool > .chip");t.forEach(function(i){i.addEventListener("click",function(){t.forEach(function(e){e.classList.remove("teal"),e.classList.remove("lighten-1"),e.classList.remove("white-text")}),this.classList.add("teal"),this.classList.add("lighten-1"),this.classList.add("white-text"),document.getElementById("searchScope").value=this.dataset.id,e.href=e.pathname+"?prikaz="+this.dataset.id})})}var i=document.querySelectorAll("select:not(.selectize)");M.FormSelect.init(i,t),i=document.querySelectorAll(".sidenav"),M.Sidenav.init(i,t),i=document.querySelectorAll(".collapsible"),M.Collapsible.init(i);t={format:"yyyy-mm-dd",firstDay:1,i18n:{cancel:"Otka\u017ei",months:["Sije\u010danj","Velja\u010da","O\u017eujak","Travnj","Svibnj","Lipanj","Srpanj","Kolovoz","Rujan","Listopad","Studeni","Prosinac"],monthsShort:["Sij","Velj","O\u017eu","Tra","Svi","Lip","Srp","Kol","Ruj","Lis","Stu","Pro"],weekdays:["Nedjelja","Ponedjeljak","Utorak","Srijeda","\u010cetvrtak","Petak","Subota"],weekdaysShort:["Ned","Pon","Uto","Sri","\u010cet","Pet","Sub"],weekdaysAbbrev:["N","P","U","S","\u010c","P","S"]}};i=document.querySelectorAll(".datepicker"),M.Datepicker.init(i,t);$("div.card-reveal input[type=radio], main.item aside div form input[type=radio]").change(function(){1==this.value?$("#"+$(this).attr("name")).removeClass("hide"):$("#"+$(this).attr("name")).addClass("hide")});const n=queryString.parse(e.search);document.querySelectorAll(".filter").forEach(function(t){t.addEventListener("change",function(){this.value?(n[this.name]=this.value,e.search=queryString.stringify(n)):e.href=e.pathname})});const o=document.getElementById("addMore");if(o){let e=0;o.addEventListener("click",t=>{t.preventDefault(),e=document.querySelector("#fieldsetContainer").lastElementChild.id.replace("code_group_codes_attributes_","").replace("_id","");const i=parseInt(e)+1,n=document.querySelector("#fieldsetContainer fieldset").outerHTML.replaceAll("0",i).replaceAll(/value=(...)/g,'value=""');document.querySelector("#fieldsetContainer").insertAdjacentHTML("afterend",n)})}$(".advanced_search_toggle").on("click",function(){$(".advanced_search").slideToggle()}),$("button.new_event").on("click",function(){$("div.new_event").slideToggle()}),$(".status_toggle").on("click",function(e){e.preventDefault(),$(this).next().slideToggle()}),$(".print").on("click",function(){var e=this.getAttribute("url"),t=window.open(e,"Print","left=200, top=200, width=950, height=500, toolbar=0, resizable=0");t.addEventListener("load",function(){Boolean(t.chrome)?(t.print(),setTimeout(function(){t.close()},500)):(t.print(),t.close())},!0)}),$(".calendar-holder").on("click",".calendar_link",function(e){e.preventDefault();const t=$(this).attr("data-event-id");$.ajax({url:"dogadaj/"+t}).done(function(e){$(".event_holder").html(e)})})});