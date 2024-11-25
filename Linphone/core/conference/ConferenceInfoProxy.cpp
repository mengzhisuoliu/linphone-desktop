/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "ConferenceInfoProxy.hpp"
#include "ConferenceInfoCore.hpp"
#include "ConferenceInfoGui.hpp"
#include "ConferenceInfoList.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceInfoProxy)

ConferenceInfoProxy::ConferenceInfoProxy(QObject *parent) : LimitProxy(parent) {
	mList = ConferenceInfoList::create();
	setSourceModels(new SortFilterList(mList.get(), Qt::AscendingOrder));
	connect(
	    mList.get(), &ConferenceInfoList::haveCurrentDateChanged, this,
	    [this] {
		    auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
		    sortModel->invalidate();
	    },
	    Qt::QueuedConnection);
	connect(
	    mList.get(), &ConferenceInfoList::confInfoInserted, this,
	    [this](int index, ConferenceInfoGui *data) {
		    auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
		    if (sortModel) {
			    auto proxyIndex = sortModel->mapFromSource(mList->index(index, 0)).row();
			    if (proxyIndex >= getMaxDisplayItems()) setMaxDisplayItems(proxyIndex + 1);
			    emit conferenceInfoCreated(proxyIndex);
		    }
	    },
	    Qt::QueuedConnection);
	connect(mList.get(), &ConferenceInfoList::initialized, this, &ConferenceInfoProxy::initialized);
}

ConferenceInfoProxy::~ConferenceInfoProxy() {
}

bool ConferenceInfoProxy::haveCurrentDate() const {
	return mList->haveCurrentDate();
}

bool ConferenceInfoProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto list = qobject_cast<ConferenceInfoList *>(sourceModel());
	auto ciCore = list->getAt<ConferenceInfoCore>(sourceRow);
	if (ciCore) {
		bool searchTextInSubject = false;
		bool searchTextInParticipant = false;
		if (ciCore->getSubject().contains(mFilterText, Qt::CaseInsensitive)) searchTextInSubject = true;
		for (auto &contact : ciCore->getParticipants()) {
			auto infos = contact.toMap();
			if (infos["displayName"].toString().contains(mFilterText, Qt::CaseInsensitive)) {
				searchTextInParticipant = true;
				break;
			}
		}
		if (!searchTextInSubject && !searchTextInParticipant) return false;
		QDateTime currentDateTime = QDateTime::currentDateTimeUtc();
		if (mFilterType == int(ConferenceInfoProxy::ConferenceInfoFiltering::None)) {
			return true;
		} else if (mFilterType == int(ConferenceInfoProxy::ConferenceInfoFiltering::Future)) {
			auto res = ciCore->getEndDateTimeUtc() >= currentDateTime;
			return res;
		} else return mFilterType == -1;
	} else {
		// if mlist count == 1 there is only the dummy row which we don't display alone
		return !list->haveCurrentDate() && list->getCount() > 1 && mFilterText.isEmpty();
	}
}

int ConferenceInfoProxy::getCurrentDateIndex() const {
	auto sortModel = dynamic_cast<SortFilterList *>(sourceModel());
	auto modelIndex = mList->getCurrentDateIndex();
	auto proxyIndex = sortModel->mapFromSource(mList->index(modelIndex, 0)).row();
	return proxyIndex;
}

bool ConferenceInfoProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft,
                                                   const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<ConferenceInfoList, ConferenceInfoCore>(sourceLeft.row());
	auto r = getItemAtSource<ConferenceInfoList, ConferenceInfoCore>(sourceRight.row());
	if (!l && !r) {
		return true;
	}
	auto nowDate = QDate::currentDate();
	if (!l || !r) { // sort on date
		auto rdate = r ? r->getDateTimeUtc().date() : QDate::currentDate();
		return !l ? nowDate <= r->getDateTimeUtc().date() : l->getDateTimeUtc().date() < nowDate;
	} else {
		return l->getDateTimeUtc() < r->getDateTimeUtc();
	}
}
