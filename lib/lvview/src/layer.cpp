#include "layer.h"

namespace lv{

Layer::Layer(QObject *parent)
    : QObject(parent)
    , m_hasView(false)
{

}

Layer::~Layer(){

}

Layer *Layer::parentLayer(){
    return qobject_cast<Layer*>(parent());
}

}// namespace
