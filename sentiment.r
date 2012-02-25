
# from http://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/
# score.sentiment(c("i like cookies", "i hate spam", "simpsons are cool"))
a.score.sentiment = function(sentences, good=NULL, bad=NULL, .progress='none') {  
  require(plyr)
  require(stringr)

  # load words from http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html
  pos.words = scan('./positive-words.txt', what='character',comment.char=';')
  neg.words = scan('./negative-words.txt', what='character',comment.char=';')

  # add more if needed
  pos.words = c(pos.words, good)
  neg.words = c(neg.words, bad)  

  # we got a vector of sentences. plyr will handle a list or a vector as an "l"
  # we want a simple array of scores back, so we use "l" + "a" + "ply" = laply:
  scores = laply(sentences, function(sentence, pos.words, neg.words) {

    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence) # and convert to lower case:
    sentence = tolower(sentence)
  
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')

    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)

    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    return(score)
    
  }, pos.words, neg.words, .progress=.progress )

  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}
