/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef ACCOUNT_PROXY_H_
#define ACCOUNT_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "core/account/AccountGui.hpp"
#include "core/account/AccountList.hpp"

// =============================================================================

class AccountProxy : public SortFilterProxy {
	Q_OBJECT

	Q_PROPERTY(QString filterText READ getFilterText WRITE setFilterText NOTIFY filterTextChanged)
	Q_PROPERTY(AccountGui *defaultAccount READ getDefaultAccount WRITE setDefaultAccount NOTIFY defaultAccountChanged)
	Q_PROPERTY(bool haveAccount READ getHaveAccount NOTIFY haveAccountChanged)

public:
	AccountProxy(QObject *parent = Q_NULLPTR);
	~AccountProxy();

	QString getFilterText() const;
	void setFilterText(const QString &filter);

	AccountGui *getDefaultAccount();             // Get a new object from List or give the stored one.
	void setDefaultAccount(AccountGui *account); // TODO
	void resetDefaultAccount();                  // Reset the default account to let UI build its new object if needed.
	Q_INVOKABLE AccountGui *findAccountByAddress(const QString &address);
	Q_INVOKABLE AccountGui *firstAccount();

	bool getHaveAccount() const;

signals:
	void filterTextChanged();
	void defaultAccountChanged();
	void haveAccountChanged();
	void accountRemoved(bool wasLast);

protected:
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

	QString mFilterText;
	AccountGui *mDefaultAccount = nullptr; // When null, a new UI object is build from List
	QSharedPointer<AccountList> mAccountList;
};

#endif
