;$(function(){
  $.getJSON("article.json", function(json){
    // categoriesにrubyが入る記事に絞る
    articles = json.articles.filter(article => article.categories.includes('ruby'));
  })
});
