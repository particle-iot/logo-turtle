class Parser
  commands: (input) ->
    repeatRE = /repeat\s+(\d+)\s*\[(.*)\]/i
    if matches = repeatRE.exec(input)
      numRepeats = Math.min( 9, parseInt(matches[1], 10) )
      motions = @motions matches[2]
    else
      numRepeats = 1
      motions = @motions input
    outputArray = []
    for _ in [1..numRepeats]
      outputArray = outputArray.concat motions
    outputArray

  motions: (input) ->
    motionsRE = /(forward|back|right|left|fd|bk|rt|lt)\s+(\d+)/ig
    outputArray = []
    while matches = motionsRE.exec(input)
      motion = matches[1].toLowerCase()
      if -1 == ['right','left','rt','lt'].indexOf(motion)
        max = 99   # max distance forward or back
      else
        max = 999  # max degrees right or left
      amount = Math.min( max, parseInt(matches[2], 10) )
      if amount isnt 0
        motion = @abbreviate motion
        outputArray.push "#{motion} #{amount}"
    outputArray

  abbreviate: (input) ->
    switch input
      when 'forward' then 'fd'
      when 'back'    then 'bk'
      when 'right'   then 'rt'
      when 'left'    then 'lt'
      else input

module.exports = Parser
