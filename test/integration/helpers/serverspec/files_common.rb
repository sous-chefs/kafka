# encoding: utf-8

shared_examples_for 'a kafka file' do
  let :kafka_file do
    file(path)
  end

  it 'exists' do
    expect(kafka_file).to be_a_file
  end

  it 'is owned by kafka' do
    expect(kafka_file).to be_owned_by 'kafka'
  end

  it 'belongs to kafka group' do
    expect(kafka_file).to be_grouped_into 'kafka'
  end
end

shared_examples_for 'an executable kafka file' do
  let :kafka_file do
    file(path)
  end

  it_behaves_like 'a kafka file'

  it 'is executable by kafka' do
    expect(kafka_file).to be_executable.by_user('kafka')
  end

  it 'is executable by root' do
    expect(kafka_file).to be_executable.by_user('root')
  end
end

shared_examples_for 'a non-executable kafka file' do
  let :kafka_file do
    file(path)
  end

  it_behaves_like 'a kafka file'

  it 'has 644 permissions' do
    expect(kafka_file).to be_mode 644
  end
end

shared_examples_for 'a kafka directory' do |opts={}|
  let :kafka_directory do
    file(path)
  end

  let :files_in_directory do
    Dir[File.join(path, '*')]
  end

  it 'exists' do
    expect(kafka_directory).to be_a_directory
  end

  it 'has 755 permissions' do
    expect(kafka_directory).to be_mode 755
  end

  it 'is owned by kafka' do
    expect(kafka_directory).to be_owned_by 'kafka'
  end

  it 'belongs to kafka group' do
    expect(kafka_directory).to be_grouped_into 'kafka'
  end

  unless opts[:skip_files]
    it 'is not empty' do
      expect(files_in_directory).not_to be_empty
    end

    context 'each file in directory' do
      it 'is owned by kafka' do
        files_in_directory.each do |file_in_directory|
          expect(file(file_in_directory)).to be_owned_by 'kafka'
        end
      end

      it 'belongs to kafka group' do
        files_in_directory.each do |file_in_directory|
          expect(file(file_in_directory)).to be_grouped_into 'kafka'
        end
      end
    end
  end
end
