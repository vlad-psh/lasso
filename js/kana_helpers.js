const romajiInput =
  "n' kya kyu kyo sha shu sho cha chu cho nya nyu nyo hya hyu hyo mya myu myo rya ryu ryo gya gyu gyo ja ju jo dya dyu dyo bya byu byo pya pyu pyo ka ki ku ke ko ga gi gu ge go sa si shi su se so za zi ji zu ze zo ta ti chi tu tsu te to da di dji du dzu de do na ni nu ne no ha hi hu fu he ho ba bi bu be bo pa pi pu pe po ma mi mu me mo ya yu yo ra ri ru re ro wa wo n a i u e o".split(
    ' '
  ) // todo add 'ja', 'tta', etc
const romajiOutput =
  'ん きゃ きゅ きょ しゃ しゅ しょ ちゃ ちゅ ちょ にゃ にゅ にょ ひゃ ひゅ ひょ みゃ みゅ みょ りゃ りゅ りょ ぎゃ ぎゅ ぎょ じゃ じゅ じょ ぢゃ ぢゅ ぢょ びゃ びゅ びょ ぴゃ ぴゅ ぴょ か き く け こ が ぎ ぐ げ ご さ し し す せ そ ざ じ じ ず ぜ ぞ た ち ち つ つ て と だ ぢ ぢ づ づ で ど な に ぬ ね の は ひ ふ ふ へ ほ ば び ぶ べ ぼ ぱ ぴ ぷ ぺ ぽ ま み む め も や ゆ よ ら り る れ ろ わ を ん あ い う え お'.split(
    ' '
  )
const romajiDouble = 'kk gg ss zz jj tt cc dd hh ff bb pp mm rr'.split(' ')
const hiraganaInput =
  'ぁぃぅぇぉゃゅょっがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ'.split(
    ''
  )
const hiraganaOutput =
  'あいうえおやゆよつかきくけこさしすせそたちつてとはひふへほはひふへほ'.split(
    ''
  )

export default (word) => {
  let sub
  let result = ''
  word = word.toLowerCase()

  while (word !== '') {
    sub = romajiDouble.findIndex((i) => word.indexOf(i) === 0)
    if (sub !== -1) {
      result += 'っ'
      word = word.slice(1)
    } else {
      sub = romajiInput.findIndex((i) => word.indexOf(i) === 0)
      if (sub !== -1) {
        result += romajiOutput[sub]
        word = word.slice(romajiInput[sub].length)
      } else {
        result += word[0]
        word = word.slice(1)
      }
    }
  }
  return result
    .split('')
    .map(function (m) {
      const i = hiraganaInput.indexOf(m)
      return i !== -1 ? hiraganaOutput[i] : m
    })
    .join('')
}
