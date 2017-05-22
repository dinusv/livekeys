#include "qdocumenthandlerstate.h"
#include "qdocumenteditfragment.h"

namespace lcv{

QDocumentHandlerState::QDocumentHandlerState()
    : m_editingFragment(0)
{
}

QDocumentHandlerState::~QDocumentHandlerState(){
    delete m_editingFragment;
}

void QDocumentHandlerState::setEditingFragment(QDocumentEditFragment *fragment){
    clearEditingFragment();
    m_editingFragment = fragment;
}

void QDocumentHandlerState::clearEditingFragment(){
    if ( m_editingFragment ){
        delete m_editingFragment;
        m_editingFragment = 0;
    }
}

}// namespace