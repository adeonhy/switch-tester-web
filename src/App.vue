<template>
  <div id="app">
    <SwitchTester/>
  </div>
</template>

<script>
import SwitchTester from './components/SwitchTester'

export default {
  name: 'App',
  components: {
    SwitchTester
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
