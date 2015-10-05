function unique(array) {
  return array.filter(function(value, index) {
    return array.indexOf(value) === index
  })
}

function Parser(content, wordlist) {
  this.str = $.trim(content)
  this.stash = []
  this.wordlist = wordlist
}

var rSpace = /^([ \t]+)/
  , rWord = /^[A-Za-z\-]+/
  , excludeList = {
      'don': true
    }

Parser.prototype.next = function() {
  var captures = ''
  if (captures = rSpace.exec(this.str)) {
    return this.skip(captures)
  } else if (captures = rWord.exec(this.str)) {
    var word = captures[0].toLowerCase()
      , wordlist = this.wordlist

    if (wordlist[word] && !excludeList[word]) {
      this.stash.push(captures[0]
        + '<span class="defintion">(' + wordlist[word].short_definition
        + ')</span>')
      this.str = this.str.substr(word.length)
      return
    } else {
      return this.skip(captures)
    }
  } else {
    return this.skip(1)
  }
}

Parser.prototype.skip = function(len) {
  var chunk = len[0]
  len = chunk ? chunk.length : len
  this.stash.push(this.str.substr(0, len))
  this.str = this.str.substr(len)
}

Parser.prototype.getContent = function() {
  while(this.str.length) { this.next() }
  var paragraphs = this.stash.join('').split(/[\r\n]/g)
  return paragraphs.map(function(paragraph) {
    return '<p>' + paragraph + '</p>'
  }).join('')
}

$(function() {
  var wordlistSource = $('.wordlist-source')
    , wordlistSourceAction = $('.wordlist-source-action')
    , btnCollapse = wordlistSource.find('.act-collapse')
    , btnExpand = wordlistSourceAction.find('.act-expand')

  btnCollapse.on('click', function() {
    wordlistSource.slideUp(function() {
      wordlistSourceAction.slideDown()
    })
  })

  btnExpand.on('click', function() {
    wordlistSourceAction.slideUp(function() {
      wordlistSource.slideDown()
    })
  })

  var wordlistForm = $('.wordlist-form')
  wordlistForm.on('submit', function(e) {
    e.preventDefault()
    var content = $(this).find('textarea[name=content]').val()
      , wordlist = unique(content.match(/[A-Za-z\-]+/g))

    wordlist = wordlist.filter(function(value) {
      return value.length > 1
    })

    if ($.trim(content) === '') { return }

    var wordlistResult = $('.wordlist-result')
    wordlistResult.text('载入中。。。')

    $.ajax({
      url: '/wordlist/get_wordlist'
    , type: 'POST'
    , contentType: 'application/json'
    , processData: false
    , data: JSON.stringify(wordlist)
    }).done(function(wordlist) {
      var parser = new Parser(content, wordlist)
      wordlistResult.html(
        parser.getContent()
      )
    })
  })
})
