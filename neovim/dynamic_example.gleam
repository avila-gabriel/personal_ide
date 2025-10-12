import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option

// Example record to decode
pub type Person {
  Person(name: String, age: Int, email: option.Option(String))
}

// Working decoder for Person
pub fn decode_person() -> decode.Decoder(Person) {
  {
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    use email <- decode.optional_field("email", "", decode.string)
    decode.success(Person(name:, age:, email: case email {
      "" -> option.None
      val -> option.Some(val)
    }))
  }
}

// Example usage
pub fn main() {
  let data = dynamic.properties([
    #(dynamic.string("name"), dynamic.string("Alice")),
    #(dynamic.string("age"), dynamic.int(30)),
    #(dynamic.string("email"), dynamic.string("alice@example.com")),
  ])

  let result = decode.run(data, decode_person())
  result
}

// Alternative for optional fields using decode.optional
pub fn decode_person_alt() -> decode.Decoder(Person) {
  {
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    use email <- decode.field("email", decode.optional(decode.string))
    decode.success(Person(name:, age:, email:))
  }
}