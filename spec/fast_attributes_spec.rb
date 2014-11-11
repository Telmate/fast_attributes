require 'spec_helper'

describe FastAttributes do
  describe '.type_casting' do
    it 'returns predefined type casting rules' do
      expect(FastAttributes.type_casting.keys).to include(String)
      expect(FastAttributes.type_casting.keys).to include(Integer)
      expect(FastAttributes.type_casting.keys).to include(Float)
      expect(FastAttributes.type_casting.keys).to include(Array)
      expect(FastAttributes.type_casting.keys).to include(Date)
      expect(FastAttributes.type_casting.keys).to include(Time)
      expect(FastAttributes.type_casting.keys).to include(DateTime)
      expect(FastAttributes.type_casting.keys).to include(BigDecimal)
    end
  end

  describe '.get_type_casting' do
    it 'returns type casting function' do
      expect(FastAttributes.get_type_casting(String)).to be_a(FastAttributes::TypeCast)
      expect(FastAttributes.get_type_casting(Time)).to be_a(FastAttributes::TypeCast)
    end
  end

  describe '.set_type_casting' do
    after do
      FastAttributes.remove_type_casting(OpenStruct)
    end

    it 'adds type to supported type casting list' do
      expect(FastAttributes.get_type_casting(OpenStruct)).to be(nil)
      FastAttributes.set_type_casting(OpenStruct, 'OpenStruct.new(a: %s)')
      expect(FastAttributes.get_type_casting(OpenStruct)).to be_a(FastAttributes::TypeCast)
    end
  end

  describe '.remove_type_casting' do
    before do
      FastAttributes.set_type_casting(OpenStruct, 'OpenStruct.new(a: %s)')
    end

    it 'removes type casting function from supported list' do
      FastAttributes.remove_type_casting(OpenStruct)
      expect(FastAttributes.get_type_casting(OpenStruct)).to be(nil)
    end
  end

  describe '.type_exists?' do
    it 'checks if type is registered' do
      expect(FastAttributes.type_exists?(DateTime)).to be(true)
      expect(FastAttributes.type_exists?(OpenStruct)).to be(false)
    end
  end

  describe '#attribute' do
    it 'raises an exception when type is not supported' do
      type  = Class.new(Object) { def self.inspect; 'CustomType' end }
      klass = Class.new(Object) { extend FastAttributes }
      expect{klass.attribute(:name, type)}.to raise_error(FastAttributes::UnsupportedTypeError, 'Unsupported attribute type "CustomType"')
      expect{klass.attribute(:name, :type)}.to raise_error(FastAttributes::UnsupportedTypeError, 'Unsupported attribute type ":type"')
    end

    it 'generates getter methods' do
      book = Book.new
      expect(book.respond_to?(:title)).to be(true)
      expect(book.respond_to?(:name)).to be(true)
      expect(book.respond_to?(:pages)).to be(true)
      expect(book.respond_to?(:price)).to be(true)
      expect(book.respond_to?(:authors)).to be(true)
      expect(book.respond_to?(:published)).to be(true)
      expect(book.respond_to?(:sold)).to be(true)
      expect(book.respond_to?(:finished)).to be(true)
      expect(book.respond_to?(:rate)).to be(true)
    end

    it 'is possible to override getter method' do
      toy = Toy.new
      expect(toy.name).to eq(' toy!')
      toy.name = 'bear'
      expect(toy.name).to eq('bear toy!')
    end

    it 'generates setter methods' do
      book = Book.new
      expect(book.respond_to?(:title=)).to be(true)
      expect(book.respond_to?(:name=)).to be(true)
      expect(book.respond_to?(:pages=)).to be(true)
      expect(book.respond_to?(:price=)).to be(true)
      expect(book.respond_to?(:authors=)).to be(true)
      expect(book.respond_to?(:published=)).to be(true)
      expect(book.respond_to?(:sold=)).to be(true)
      expect(book.respond_to?(:finished=)).to be(true)
      expect(book.respond_to?(:rate=)).to be(true)
    end

    it 'is possible to override setter method' do
      toy = Toy.new
      expect(toy.price).to be(nil)
      toy.price = 2
      expect(toy.price).to eq(4)
    end

    it 'setter methods convert values to correct datatype' do
      book = Book.new
      book.title     = 123
      book.name      = 456
      book.pages     = '250'
      book.price     = '2.55'
      book.authors   = 'Jobs'
      book.published = '2014-06-21'
      book.sold      = '2014-06-21 20:45:15'
      book.finished  = '2014-05-20 21:35:20'
      book.rate      = '4.1'

      expect(book.title).to eq('123')
      expect(book.name).to eq('456')
      expect(book.pages).to be(250)
      expect(book.price).to eq(BigDecimal.new('2.55'))
      expect(book.authors).to eq(%w[Jobs])
      expect(book.published).to eq(Date.new(2014, 6, 21))
      expect(book.sold).to eq(Time.new(2014, 6, 21, 20, 45, 15))
      expect(book.finished).to eq(DateTime.new(2014, 5, 20, 21, 35, 20))
      expect(book.rate).to eq(4.1)
    end

    it 'setter methods accept values which are already in a proper type' do
      book = Book.new
      book.title     = title     = 'One'
      book.name      = name      = 'Two'
      book.pages     = pages     = 250
      book.price     = price     = BigDecimal.new('2.55')
      book.authors   = authors   = %w[Jobs]
      book.published = published = Date.new(2014, 06, 21)
      book.sold      = sold      = Time.new(2014, 6, 21, 20, 45, 15)
      book.finished  = finished  = DateTime.new(2014, 05, 20, 21, 35, 20)
      book.rate      = rate      = 4.1

      expect(book.title).to be(title)
      expect(book.name).to be(name)
      expect(book.pages).to be(pages)
      expect(book.price).to eq(price)
      expect(book.authors).to be(authors)
      expect(book.published).to be(published)
      expect(book.sold).to be(sold)
      expect(book.finished).to be(finished)
      expect(book.rate).to be(rate)
    end

    it 'setter methods accept nil values' do
      book = Book.new
      book.title     = 'One'
      book.name      = 'Two'
      book.pages     = 250
      book.price     = BigDecimal.new('2.55')
      book.authors   = %w[Jobs]
      book.published = Date.new(2014, 06, 21)
      book.sold      = Time.new(2014, 6, 21, 20, 45, 15)
      book.finished  = DateTime.new(2014, 05, 20, 21, 35, 20)
      book.rate      = 4.1

      book.title     = nil
      book.name      = nil
      book.pages     = nil
      book.price     = nil
      book.authors   = nil
      book.published = nil
      book.sold      = nil
      book.finished  = nil
      book.rate      = nil

      expect(book.title).to be(nil)
      expect(book.name).to be(nil)
      expect(book.pages).to be(nil)
      expect(book.price).to be(nil)
      expect(book.authors).to be(nil)
      expect(book.published).to be(nil)
      expect(book.sold).to be(nil)
      expect(book.finished).to be(nil)
      expect(book.rate).to be(nil)
    end

    it 'setter methods raise an exception when cannot parse values' do
      object = BasicObject.new
      def object.to_s; self; end

      book = Book.new
      expect{ book.title = object }.to raise_error(FastAttributes::TypeCast::InvalidValueError, /Invalid value.*BasicObject.*for attribute "title" of type "String"/)
      expect{ book.name = object }.to raise_error(FastAttributes::TypeCast::InvalidValueError,  /Invalid value.*BasicObject.*for attribute "name" of type "String"/)
      expect{ book.pages = 'number' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "number" for attribute "pages" of type "Integer"')
      expect{ book.price = 'bigdecimal' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "bigdecimal" for attribute "price" of type "BigDecimal"')
      expect{ book.published = 'date' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "date" for attribute "published" of type "Date"')
      expect{ book.sold = 'time' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "time" for attribute "sold" of type "Time"')
      expect{ book.finished = 'datetime' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "datetime" for attribute "finished" of type "DateTime"')
      expect{ book.rate = 'float' }.to raise_error(FastAttributes::TypeCast::InvalidValueError, 'Invalid value "float" for attribute "rate" of type "Float"')
    end

    it 'setter method can escape placeholder using double %' do
      placeholder = PlaceholderClass.new
      placeholder.value = 3
      expect(placeholder.value).to eq('value %s %value %%s 2')
    end

    it 'setter method can accept %a placeholder which return attribute name' do
      placeholder = PlaceholderClass.new

      placeholder.title = 'attribute name 1'
      expect(placeholder.title).to eq('title')

      placeholder.title = 'attribute name 2'
      expect(placeholder.title).to eq('title%a%title%title!')
    end

    it 'generates lenient attributes which do not correspond to a particular data type' do
      lenient_attribute = LenientAttributes.new
      expect(lenient_attribute.terms_of_service).to be(nil)

      lenient_attribute.terms_of_service = 'yes'
      expect(lenient_attribute.terms_of_service).to be(true)

      lenient_attribute.terms_of_service = 'no'
      expect(lenient_attribute.terms_of_service).to be(false)

      lenient_attribute.terms_of_service = 42
      expect(lenient_attribute.terms_of_service).to be(nil)
    end

    it 'allows to define attributes using symbols as a data type' do
      book = DefaultLenientAttributes.new
      book.title     = title     = 'One'
      book.pages     = pages     = 250
      book.price     = price     = BigDecimal.new('2.55')
      book.authors   = authors   = %w[Jobs]
      book.published = published = Date.new(2014, 06, 21)
      book.sold      = sold      = Time.new(2014, 6, 21, 20, 45, 15)
      book.finished  = finished  = DateTime.new(2014, 05, 20, 21, 35, 20)
      book.rate      = rate      = 4.1

      expect(book.title).to be(title)
      expect(book.pages).to be(pages)
      expect(book.price).to eq(price)
      expect(book.authors).to be(authors)
      expect(book.published).to be(published)
      expect(book.sold).to be(sold)
      expect(book.finished).to be(finished)
      expect(book.rate).to be(rate)
    end

    context 'boolean attribute' do
      let(:object) { DefaultLenientAttributes.new }

      context 'when value is not set' do
        it 'return nil' do
          expect(object.active).to be(nil)
        end
      end

      context 'when value represents true' do
        it 'returns true' do
          object.active = true
          expect(object.active).to be(true)

          object.active = 1
          expect(object.active).to be(true)

          object.active = '1'
          expect(object.active).to be(true)

          object.active = 't'
          expect(object.active).to be(true)

          object.active = 'T'
          expect(object.active).to be(true)

          object.active = 'true'
          expect(object.active).to be(true)

          object.active = 'TRUE'
          expect(object.active).to be(true)

          object.active = 'on'
          expect(object.active).to be(true)

          object.active = 'ON'
          expect(object.active).to be(true)
        end
      end

      context 'when value represents false' do
        it 'returns false' do
          object.active = false
          expect(object.active).to be(false)

          object.active = 0
          expect(object.active).to be(false)

          object.active = '0'
          expect(object.active).to be(false)

          object.active = 'f'
          expect(object.active).to be(false)

          object.active = 'F'
          expect(object.active).to be(false)

          object.active = 'false'
          expect(object.active).to be(false)

          object.active = 'FALSE'
          expect(object.active).to be(false)

          object.active = 'off'
          expect(object.active).to be(false)

          object.active = 'OFF'
          expect(object.active).to be(false)
        end
      end
    end
  end

  describe '#define_attributes' do
    describe 'option initialize: true' do
      it 'generates initialize method' do
        reader = Reader.new(name: 104, age: '23')
        expect(reader.name).to eq('104')
        expect(reader.age).to be(23)
      end

      it 'is possible to override initialize method' do
        window = Window.new
        expect(window.height).to be(200)
        expect(window.width).to be(80)

        window = Window.new(height: 210, width: 100)
        expect(window.height).to be(210)
        expect(window.width).to be(100)
      end
    end

    describe 'option attributes: true' do
      it 'generates attributes method' do
        publisher = Publisher.new
        expect(publisher.attributes).to eq({'name' => nil, 'books' => nil})

        reader = Reader.new
        expect(reader.attributes).to eq({'name' => nil, 'age' => nil})
      end

      it 'is possible to override attributes method' do
        window = Window.new(height: 220, width: 100)
        expect(window.attributes).to eq({'height' => 220, 'width' => 100, 'color' => 'white'})
      end

      it 'attributes method return all attributes with their values' do
        publisher = Publisher.new
        publisher.name  = 101
        publisher.books = '20'
        expect(publisher.attributes).to eq({'name' => '101', 'books' => 20})

        reader = Reader.new
        reader.name = 102
        reader.age  = '25'
        expect(reader.attributes).to eq({'name' => '102', 'age' => 25})
      end
    end
  end

  describe 'ActiveModel::Dirty support' do
    require 'active_model'

    it 'should track changes if ActiveModel::Dirty is included' do
      class DirtyMagazine
        include ActiveModel::Dirty
        extend FastAttributes
        define_attributes initialize: true, attributes: true do
          attribute :title, :issue, String
        end
      end

      mag = DirtyMagazine.new(:title => 'Rustler')
      expect(mag.changes).to be_empty
      mag.issue = nil # no change
      expect(mag.changes).to be_empty
      mag.title = 'Crustler'
      expect(mag.changes).to eq({"title" => ["Rustler", "Crustler"]})
      mag.issue = nil # no change
      expect(mag.changes).to eq({"title" => ["Rustler", "Crustler"]})
      mag.issue = "41"
      expect(mag.changes).to eq({"title" => ["Rustler", "Crustler"], "issue" => [nil, "41"]})

    end

  end
end
