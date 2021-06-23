shared_examples 'has_one_attached_and_prepare_image' do |attr_name, options|
  context "has #{attr_name}=" do
    subject { described_class.new }

    it 'runs image processing and create attachment' do
      attachment = fixture_file_upload('helmet_cat.png', 'image/png', :binary)
      expect(ImagePreparer).to receive(:new).with(attr_name, attachment, options || {}).and_call_original
      expect(ActiveStorage::Attached::Changes::CreateOne).to receive(:new).with(attr_name, subject, attachment).and_call_original

      subject.send("#{attr_name}=", attachment)
    end

    it 'delete attachment for nil provided' do
      expect(ImagePreparer).to receive(:new).with(attr_name, nil, options || {}).and_call_original
      expect(ActiveStorage::Attached::Changes::DeleteOne).to receive(:new).with(attr_name, subject).and_call_original

      subject.send("#{attr_name}=", nil)
    end
  end
end
