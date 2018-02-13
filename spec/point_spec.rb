require_relative '../lib/rubycopter/point'

describe Point do
  subject(:point) { described_class.new }
  context 'on point' do
    it 'is added correctly' do
      expect(Point.new(1, 2) + Point.new(3, -4)).to eq Point.new(4, -2)
    end

    it 'is subtracted correctly' do
      expect(Point.new(1, 2) - Point.new(3, -4)).to eq Point.new(-2, 6)
    end

    it 'is multiplied correctly' do
      expect(Point.new(1, 2) * Point.new(3, -4)).to eq Point.new(3, -8)
    end
  end

  context 'on number' do
    it 'is multiplied correctly' do
      expect(Point.new(1, 2) * 4).to eq Point.new(4, 8)
    end
  end
end
