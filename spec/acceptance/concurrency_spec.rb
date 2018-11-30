require 'spec_helper_acceptance'

describe 'with file recursive purge' do
  before(:all) do
    @basedir = setup_test_directory
  end
  context 'when run should still create concat file' do
    let(:pp) do
      <<-MANIFEST
      file { '#{@basedir}/bar':
        ensure => directory,
        purge  => true,
        recurse => true,
      }

      concat { "foobar":
        ensure => 'present',
        path   => '#{@basedir}/bar/foobar',
      }

      concat::fragment { 'foo':
        target => 'foobar',
        content => 'foo',
      }
    MANIFEST
    end

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
      expect(file("#{@basedir}/bar/foobar")).to be_file
      expect(file("#{@basedir}/bar/foobar").content).to match 'foo'
    end
  end
end
