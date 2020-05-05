;$(function(){
    var toc = $('.post-content-toc');
    var sidebar = $('.sidebar');
    var article = $('article');
    sidebar.height(article.height());
    toc.clone(false).appendTo($('#side-toc-id'));
});

