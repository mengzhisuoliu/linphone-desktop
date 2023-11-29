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

#include "VariantObject.hpp"

#include <QDebug>
#include <QTest>

#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(VariantObject)
VariantObject::VariantObject(QObject *parent) : VariantObject(QVariant()) {
}
VariantObject::VariantObject(QVariant defaultValue, QObject *parent) {
	mCoreObject = QSharedPointer<SafeObject>::create(defaultValue);
	mModelObject = QSharedPointer<SafeObject>::create();
	mModelObject->moveToThread(CoreModel::getInstance()->thread());

	mConnection = QSharedPointer<SafeConnection>(
	    new SafeConnection(mCoreObject.objectCast<QObject>(), mModelObject.objectCast<QObject>()),
	    &QObject::deleteLater);

	mConnection->makeConnect(mCoreObject.get(), &SafeObject::setValue, [this](QVariant value) {
		mConnection->invokeToModel([this, value]() { mModelObject->onSetValue(value); });
	});
	mConnection->makeConnect(mModelObject.get(), &SafeObject::setValue, [this](QVariant value) {
		mConnection->invokeToCore([this, value]() { mCoreObject->onSetValue(value); });
	});
	mConnection->makeConnect(mModelObject.get(), &SafeObject::valueChanged, [this](QVariant value) {
		mConnection->invokeToCore([this, value]() { mCoreObject->valueChanged(value); });
	});
	connect(mCoreObject.get(), &SafeObject::valueChanged, this, &VariantObject::valueChanged);
}

VariantObject::~VariantObject() {
}

QVariant VariantObject::getValue() const {
	return mCoreObject->getValue();
}

void VariantObject::requestValue() {
	emit mCoreObject->requestValue();
}