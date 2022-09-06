#  OpenProject is an open source project management software.
#  Copyright (C) 2010-2022 the OpenProject GmbH
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License version 3.
#
#  OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
#  Copyright (C) 2006-2013 Jean-Philippe Lang
#  Copyright (C) 2010-2013 the ChiliProject Team
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#  See COPYRIGHT and LICENSE files for more details.

require 'spec_helper'

describe WorkPackages::UpdateAncestors::Loader, type: :model do
  describe '#select' do
    shared_let(:grandgrandparent) do
      create :work_package
    end
    shared_let(:grandparent_sibling) do
      create :work_package,
             parent: grandgrandparent
    end
    shared_let(:grandparent) do
      create :work_package,
             parent: grandgrandparent
    end
    shared_let(:parent) do
      create :work_package,
             parent: grandparent
    end
    shared_let(:sibling) do
      create :work_package,
             parent:
    end
    shared_let(:work_package) do
      create :work_package,
             parent:
    end
    shared_let(:child) do
      create :work_package,
             parent: work_package
    end

    let(:include_former_ancestors) { true }

    subject do
      work_package.parent = new_parent
      work_package.save!

      described_class
        .new(work_package, include_former_ancestors)
    end

    context 'when switching the hierarchy' do
      let!(:new_grandgrandparent) do
        create :work_package,
               subject: 'new grandgrandparent'
      end
      let!(:new_grandparent) do
        create :work_package,
               parent: new_grandgrandparent,
               subject: 'new grandparent'
      end
      let!(:new_parent) do
        create :work_package,
               subject: 'new parent',
               parent: new_grandparent
      end
      let!(:new_sibling) do
        create :work_package,
               subject: 'new sibling',
               parent: new_parent
      end

      it 'iterates over both current and former ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [new_parent, new_grandparent, new_grandgrandparent, parent, grandparent, grandgrandparent]
      end
    end

    context 'when switching the hierarchy and not including the former ancestors' do
      let!(:new_grandgrandparent) do
        create :work_package,
               subject: 'new grandgrandparent'
      end
      let!(:new_grandparent) do
        create :work_package,
               parent: new_grandgrandparent,
               subject: 'new grandparent'
      end
      let!(:new_parent) do
        create :work_package,
               subject: 'new parent',
               parent: new_grandparent
      end
      let!(:new_sibling) do
        create :work_package,
               subject: 'new sibling',
               parent: new_parent
      end

      let(:include_former_ancestors) { false }

      it 'iterates over the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [new_parent, new_grandparent, new_grandgrandparent]
      end
    end


    context 'when removing the parent' do
      let(:new_parent) { nil }

      it 'iterates over the former ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [parent, grandparent, grandgrandparent]
      end
    end

    context 'when removing the parent and not including the former ancestors' do
      let(:new_parent) { nil }
      let(:include_former_ancestors) { false }

      it 'loads nothing' do
        expect(subject.select { |ancestor| ancestor })
          .to be_empty
      end
    end

    context 'when changing the parent within the same hierarchy upwards' do
      let(:new_parent) { grandgrandparent }

      it 'iterates over the former ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [parent, grandparent, grandgrandparent]
      end
    end

    context 'when changing the parent within the same hierarchy upwards and not loading former ancestors' do
      let(:new_parent) { grandgrandparent }
      let(:include_former_ancestors) { false }

      it 'iterates over the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [grandgrandparent]
      end
    end

    context 'when changing the parent within the same hierarchy sideways' do
      let(:new_parent) { sibling }

      it 'iterates over the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [sibling, parent, grandparent, grandgrandparent]
      end
    end

    context 'when changing the parent within the same hierarchy sideways and not loading former ancestors' do
      let(:new_parent) { sibling }
      let(:include_former_ancestors) { false }

      it 'iterates over the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [sibling, parent, grandparent, grandgrandparent]
      end
    end

    context 'when changing the parent within the same hierarchy sideways but to a different level' do
      let(:new_parent) { grandparent_sibling }

      it 'iterates over the former and the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [grandparent_sibling, parent, grandparent, grandgrandparent]
      end
    end

    context 'when changing the parent within the same hierarchy sideways but to a different level and not loading ancestors' do
      let(:new_parent) { grandparent_sibling }
      let(:include_former_ancestors) { false }

      it 'iterates over the former and the current ancestors' do
        expect(subject.select { |ancestor| ancestor })
          .to eql [grandparent_sibling, grandgrandparent]
      end
    end
  end
end
