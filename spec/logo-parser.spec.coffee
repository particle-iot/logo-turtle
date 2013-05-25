SparkLogo = require '../lib/spark-logo'

describe SparkLogo, ->
  it 'is an object, i.e., a namespace/module', ->
    expect(typeof SparkLogo).toEqual('object')

  describe SparkLogo.Parser, ->
    parser = null
    beforeEach ->
      parser = new SparkLogo.Parser

    it 'is a function, i.e., a CoffeeScript class', ->
      expect(typeof SparkLogo.Parser).toEqual('function')

    it 'can be constructed (in beforeEach)', ->
      expect(typeof parser).toEqual('object')

    describe 'commands', ->
      it 'outputs commands in lowercase', ->
        commands = parser.commands 'FORwaRD 12'
        expect(commands).toEqual(['fd 12'])

      it 'is an empty array if no commands are found', ->
        expect(parser.commands('fleeblgerble 92')).toEqual([])

      it 'finds two commands amidst other stuff', ->
        commands = parser.commands 'forward 10 hey hey hey back 3 nanana'
        expect(commands).toEqual(['fd 10','bk 3'])

      it 'collapses whitespace within commands to a single space', ->
        expect(parser.commands('left  \t \r\n \n 60')).toEqual(['lt 60'])

      it 'ignores commands with negative numbers', ->
        expect(parser.commands('fd -3')).toEqual([])

      it 'ignores commands with zero', ->
        expect(parser.commands('bk 0')).toEqual([])

      it 'truncates decimals, only using the integer part', ->
        expect(parser.commands('fd 10.9')).toEqual(['fd 10'])

      it 'recognizes commands case insensitively', ->
        commands = parser.commands 'FORwaRD 1'
        expect(commands.length).toEqual(1)

      describe 'forward', ->
        it 'recognizes the forward command alone', ->
          expect(parser.commands('forward 5')).toEqual(['fd 5'])

        it 'recognizes the forward command amidst gibberish', ->
          commands = parser.commands 'gibberish.example.com forward 10 gibberish'
          expect(commands).toEqual(['fd 10'])

        it 'will not go more than 99 forward', ->
          expect(parser.commands('forward 150')).toEqual(['fd 99'])
      
      describe 'back', ->
        it 'recognizes the back command alone', ->
          expect(parser.commands('back 2')).toEqual(['bk 2'])

        it 'recognizes the back command admist gibberish', ->
          commands = parser.commands 'nananana back 7'
          expect(commands).toEqual(['bk 7'])

      describe 'right', ->
        it 'recognizes the right command amidst gibberish', ->
          expect(parser.commands('@heyhey right 90 asdfasdf')).toEqual(['rt 90'])

        it 'will not turn right more than 999 degrees', ->
          expect(parser.commands('right 1500')).toEqual(['rt 999'])

      describe 'left', ->
        it 'recognizes the left command amidst gibberish', ->
          expect(parser.commands(' "  left 180 #awesome')).toEqual(['lt 180'])

        it 'will not turn left more than 999 degrees', ->
          expect(parser.commands('left 1500')).toEqual(['lt 999'])

      describe 'abbreviated movements', ->
        it 'recognizes the fd command', ->
          expect(parser.commands('fd 2')).toEqual(['fd 2'])

        it 'recognizes the bk command', ->
          expect(parser.commands('bk 1')).toEqual(['bk 1'])

        it 'recognizes the rt command', ->
          expect(parser.commands('rt 30')).toEqual(['rt 30'])

        it 'recognizes the lt command', ->
          expect(parser.commands('lt 120')).toEqual(['lt 120'])

      describe 'repeat', ->
        it 'flattens to an array of individual motion commands', ->
          commands = parser.commands 'repeat 2 [fd 1 rt 60]'
          expect(commands).toEqual(['fd 1', 'rt 60', 'fd 1', 'rt 60'])

        it 'ignores nested repeats', ->
          commands = parser.commands 'repeat 2 [fd 1 repeat 3 [rt 90] bk 2]'
          expect(commands).toEqual(['fd 1', 'rt 90', 'bk 2', 'fd 1', 'rt 90', 'bk 2'])

        it 'ignores commands outside repeat if repeat is present', ->
          commands = parser.commands 'bk 9 repeat 2 [fd 7] bk 8'
          expect(commands).toEqual(['fd 7', 'fd 7'])

        it 'repeats no more than 9 times', ->
          commands = parser.commands 'repeat 15 [fd 1]'
          expected = ['fd 1', 'fd 1', 'fd 1',
                      'fd 1', 'fd 1', 'fd 1',
                      'fd 1', 'fd 1', 'fd 1']
          expect(commands).toEqual(expected)
