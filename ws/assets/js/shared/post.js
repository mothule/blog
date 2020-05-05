;$(function(){
    var windowWidth = $(window).width();
    if(windowWidth > 991) {
        var toc = $('.post-content-toc');
        var sidebar = $('.sidebar');
        var article = $('article');
        sidebar.height(article.height());
        $('#side-toc-id').append('<p>目次</p>')
        toc.clone(false).appendTo($('#side-toc-id'));
    }
});
