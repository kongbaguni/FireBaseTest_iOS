
function makeIndex() {
    function addLink(item, index) {
        var link = document.createElement("a");
        $(link).text(item);
        $(link).attr("href","#h"+index)
        var li = document.createElement("li");
        $(li).append(link)
        $("#navi > ul").append(li);
    }
    var count = 0
    var titles = new Array();
    $("h2").each(function() {
        $(this).attr("id","h"+count);
        count += 1;
        titles.push($(this).text());
    });
    var nav = document.createElement("nav")
    $(nav).attr("id","navi")
    $("article:first-of-type").before(nav);
    var ul = document.createElement("ul")
    $(nav).append(ul);
    titles.forEach(addLink);
}

$(document).ready(function(){
    makeIndex();
})
