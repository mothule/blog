;$(function(){
    var toc = $('.post-content-toc');
    var sidebar = $('.sidebar');
    var article = $('article');
    console.log('article tag height:' + article.height());
    console.log('sidebar class height:' + sidebar.height());
    sidebar.height(article.height());
    toc.clone(false).appendTo($('#side-toc-id'));

});

