<template>
  <div class="tester">
    <div v-if="currentSwitch">
      <p>押したスイッチ: {{currentSwitch.name}}</p>
      <img :src="require('../assets/' + this.currentSwitch.img)" style="width: 25%; height: 25%">
      <p>荷重: {{currentSwitch.weight}}</p>
      <p>種類: {{currentSwitch.type}}</p>
      <p>価格: {{currentSwitch.price}}</p>
    </div>
    <div v-else>
      <img src="../assets/computer_blindtouch.png" style="width: 25%; height: 25%">
      <p>スイッチを押してね！</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SwitchTester',
  data () {
    return {
      clearCount: 10,
      clearInterval: 5,
      currentSwitch: null,
      switches: {
        a: { name: 'Gateron Red', type: 'リニア', weight: '45g', price: '48', img: 'A0200GA-RE.jpg' },
        b: { name: 'Gateron Brown', type: 'タクタイル', weight: '45g', price: '48', img: 'A0200GA-BR.jpg' },
        c: { name: 'Gateron Blue', type: 'クリッキー', weight: '45g', price: '48', img: 'A0200GA-BL.jpg' },
        d: { name: 'Gateron Clear', type: 'リニア', weight: '35g', price: '48', img: 'A0200GA-CL.jpg' }
      }
    }
  },
  mounted () {
    document.addEventListener('keypress', this.keyPress)
    setInterval(() => { this.count() }, 1000)
  },
  methods: {
    keyPress (e) {
      this.currentSwitch = this.switches[e.key]
      this.clearCount = this.clearInterval
    },
    count () {
      this.clearCount -= 1
      if (this.clearCount <= 0) {
        this.reset()
      }
    },
    reset () {
      this.clearCount = this.clearInterval
      this.currentSwitch = null
    }
  }
}
</script>

<style scoped>
</style>
