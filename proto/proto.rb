class MPS7
  TYPES = %i[
    debit
    credit
    start_autopay
    end_autopay
  ].freeze

  SCHEMA = {
    type: { bytes: 1, format: 'C' },
    timestamp: { bytes: 4, format: 'L>' },
    user_id: { bytes: 8, format: 'Q>' },
    amount: { bytes: 8, format: 'G' }
  }.freeze

  def initialize(file_path)
    parse_file(file_path)
  end

  def total_debits
    total(:debit)
  end

  def total_credits
    total(:credit)
  end

  def num_started_autopays
    num(:start_autopay)
  end

  def num_ended_autopays
    num(:end_autopay)
  end

  def user_balance(user_id)
    @records
      .select{|r| r[:user_id] == user_id && r[:amount]}
      .map{|r| r[:type] == :credit ? r[:amount] : -r[:amount]}
      .reduce(:+)
  end

  private
  
  def total(type)
    @records.select{|r| r[:type] == type}.map{|r| r[:amount]}.reduce(:+)
  end

  def num(type)
    @records.select{|r| r[:type] == type}.count
  end

  def parse_file(file_path)
    data = File.read('txnlog.dat', binmode: true)

    count = data[5..8].unpack('L>').first

    @records = []
    i = 8
    count.times do
      record = {
        type: TYPES[data[i+1..i+=SCHEMA[:type][:bytes]].unpack('C').first], 
        timestamp: data[i+1..i+=SCHEMA[:timestamp][:bytes]].unpack('L>').first,
        user_id: data[i+1..i+=SCHEMA[:user_id][:bytes]].unpack('Q>').first  
      }
      if %i[debit credit].include? record[:type]                                        
        record[:amount] = data[i+1..i+=SCHEMA[:amount][:bytes]].unpack('G').first
      end

      @records << record
    end
  end
end

mps7 = MPS7.new('txnlog.dat')
p "What is the total amount in dollars of debits? => #{mps7.total_debits}"
p "What is the total amount in dollars of credits? => #{mps7.total_credits}"
p "How many autopays were started? => #{mps7.num_started_autopays}"
p "How many autopays were ended? => #{mps7.num_ended_autopays}"
p "What is balance of user ID 2456938384156277127? => #{mps7.user_balance(2456938384156277127)}"
