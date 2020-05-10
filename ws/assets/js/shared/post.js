---
---
;$(function(){
    var windowWidth = $(window).width();
    if(windowWidth > 991) {
        buildTableOfContentsOnSide()
        buildShareButtonsOnSide()
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
    function buildShareButtonsOnSide() {
      var hatena_bookmark_button = `
      <li>{% include hatena_bookmark_button.html %}</li>
      `;

      var pocket_button = `
        {% include pocket_button.html %}
      `;
      $('#side-share-id>ul').append(pocket_button);
      $('#side-share-id>ul').append(hatena_bookmark_button);
  }
});
