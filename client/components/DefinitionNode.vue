<template>
  <span class="definition-node" :class="nodeName">
    <template v-for="(c, idx) of children">
      <template v-if="c.items">
        <DefinitionNode
          :key="`d${idx}`"
          :children="c.items"
          :node-name="c.name"
        ></DefinitionNode>
      </template>
      <template v-else-if="c.t"
        ><a :key="`d${idx}`" :href="path(c.q)" @click.prevent="search(c.q)">{{
          c.t
        }}</a></template
      >
      <template v-else>{{ c }}</template>
    </template>
  </span>
</template>

<script>
export default {
  props: {
    nodeName: { type: String, required: true },
    children: { type: Array, required: true },
  },
  methods: {
    path(query) {
      return this.$router.resolve({
        name: 'sub-search',
        params: { query },
      }).href
    },
    search(query) {
      this.$search.execute({ query, mode: 'primary', popRoute: true })
    },
  },
}
</script>

<style lang="scss">
.definition-node {
  line-height: 1.7em;

  a {
    text-decoration: none;
    color: inherit;
    background: var(--bg-secondary);
    border: 1px solid var(--bg);
  }

  &.gloss-line + &.gloss-line {
    display: block;
    min-height: 1em;
    text-indent: 1em;
  }
  &.subscript {
    vertical-align: super;
    color: #ca1717;
    font-size: 0.7em;
    line-height: 0.5em;
  }
  &.decoration {
    font-weight: bold;
    color: #ca1717;
  }
  &.badge {
    font-size: 0.9em;
    font-weight: bold;
    border-radius: 0.15em;
    padding: 0 0.15em;
    margin: 0 0.15em;

    &,
    & a {
      border: none;
      background: var(--color);
      color: var(--bg);
    }
  }
}
</style>
