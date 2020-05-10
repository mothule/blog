;$(function(){
    var windowWidth = $(window).width();
    if(windowWidth > 991) {
        buildTableOfContentsOnSide()
        showShareButtonsOnSide()
    }

    // Table of Contents作成
    function buildTableOfContentsOnSide() {
      var toc = $('.post-content-toc');
      var sidebar = $('.sidebar');
      var article = $('article');
      sidebar.height(article.height());
      $('#side-toc-id').append('<p>目次</p>')
      toc.clone(false).appendTo($('#side-toc-id'));
    }

    // シェアボタン群作成
    function showShareButtonsOnSide() {
      $('#side-share-id').css('display', 'block');
    }
});
