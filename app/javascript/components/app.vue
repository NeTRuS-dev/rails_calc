<template>
  <div class="container-fluid mt-5">
    <div v-if="error_msg" class="row">
      <div class="col-8 offset-2">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
          {{ error_msg }}
          <button @click="error_msg=''" type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </div>
    </div>
    <div v-if="success_msg" class="row">
      <div class="col-8 offset-2">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
          {{ success_msg }}
          <button @click="success_msg=''" type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-8 offset-2">
        <div class="container-fluid">
          <h1 class="mb-3">Калькулятор</h1>
          <div class="d-flex justify-content-center">
            <input v-model="a_val" type="number" class="form-control mr-2">
            <select v-model="selected_operation" class="form-control mr-2">
              <option disabled :selected="!selected_operation">Выберите операцию</option>
              <option :selected="selected_operation===op" v-for="(op,ind) in operations" :key="ind" :value="op">{{ op }}
              </option>
            </select>
            <input v-if="show_b_input" v-model="b_val" type="number" class="form-control">
          </div>
          <div class="row mt-3 mb-5">
            <div class="col-2 ml-auto d-flex">
              <button @click="calc" class="btn btn-primary">
                Посчитать
              </button>
            </div>
          </div>

          <div class="h2 text-center mx-5 px-5" v-if="result">{{ result }}</div>

          <div class="row mt-5">
            <div class="col d-flex justify-content-end mt-5">
              <button @click="get_memorized" class="btn btn-info mr-3">
                Отобразить значение из памяти
              </button>
              <button v-if="result!==''&&result!==undefined" @click="memorize" class="btn btn-success mr-3">
                Запомнить получившееся значение
              </button>
              <button @click="forget" class="btn btn-danger">
                Забыть значение в памяти
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      success_msg: '',
      token: null,
      error_msg: '',
      a_val: '',
      b_val: '',
      selected_operation: '',
      result: '',
      operations: [
        '+',
        '-',
        '*',
        '/',
        'sin',
        'cos',
        'tg',
        'ctg',
        'log',
        '!',
        '^',
      ],

    }
  },
  methods: {
    calc() {
      if (this.operations.includes(this.selected_operation) && this.a_val) {
        this.result = ''

        fetch('/calculations/calc', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.token
          },
          body: JSON.stringify({
            a: this.a_val,
            b: this.b_val,
            operation: this.selected_operation
          })
        })
            .then((response) => {
              return response.json();
            })
            .then((data) => {
              this.result = ''
              this.error_msg = ''
              if (data.status == 0) {
                this.result = data.message
              } else {
                this.error_msg = data.message
              }
            });
      } else {
        this.error_msg = 'Заполните информацию для вычисления'
      }
    },
    memorize() {
      fetch('/calculations/memorize', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.token
        },
        body: JSON.stringify({
          value: this.result
        })
      }).then((response) => {
        return response.json();
      }).then((data) => {
        this.success_msg = data.message
      });
    },
    forget() {
      fetch('/calculations/clear-memory', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.token
        },
        body: JSON.stringify({})
      })
      this.success_msg = 'Память успешно очищена'
    },
    get_memorized() {
      fetch('/calculations/get-memorized', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.token
        },
        body: JSON.stringify({})
      })
          .then((response) => {
            return response.json();
          })
          .then((data) => {
            this.result = ''
            this.error_msg = ''
            if (data.status == 0) {
              this.result = data.value
            } else {
              this.error_msg = data.value
            }
          });
    },
  },
  computed: {
    show_b_input() {
      return !([
        '!',
        'sin',
        'cos',
        'tg',
        'ctg',
        'log',
      ].includes(this.selected_operation))
    },
  },
  mounted() {
    this.token = document.querySelector('meta[name="csrf-token"]').content;
  }
}
</script>

<style lang="scss" scoped>
</style>
