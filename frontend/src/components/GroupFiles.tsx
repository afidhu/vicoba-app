import React, { useEffect, useState } from 'react';
import { attachmentsApi } from '../api/endpoints';
import { GroupAttachment } from '../types';
import { formatDate } from '../utils/format';

export default function GroupFiles({ groupId, canDelete }: { groupId: string; canDelete: boolean }) {
  const [files, setFiles] = useState<GroupAttachment[]>([]);
  const [error, setError] = useState('');
  const [preview, setPreview] = useState<{ file: GroupAttachment; url: string } | null>(null);

  async function load() {
    try {
      const { data } = await attachmentsApi.list(groupId);
      setFiles(data);
    } catch {
      setError('Unable to load group files');
    }
  }

  useEffect(() => {
    load();
  }, [groupId]);

  async function viewFile(file: GroupAttachment) {
    const { data } = await attachmentsApi.download(groupId, file.id);
    const url = URL.createObjectURL(data);
    setPreview({ file, url });
  }

  async function deleteFile(file: GroupAttachment) {
    if (!window.confirm(`Delete ${file.fileName}?`)) return;
    await attachmentsApi.remove(groupId, file.id);
    await load();
  }

  return (
    <div>
      {error && <div className="alert alert-danger py-2">{error}</div>}
      {files.length === 0 ? (
        <div className="text-muted py-2">No files uploaded for this group.</div>
      ) : (
        <div className="list-group list-group-flush">
          {files.map((file) => (
            <div key={file.id} className="list-group-item px-0 d-flex justify-content-between align-items-center">
              <div className="text-truncate me-2">
                <i className="bi bi-paperclip me-2" />
                <span>{file.fileName}</span>
                <small className="text-muted d-block ms-4">
                  {file.uploadedBy?.name || 'Group member'} · {formatDate(file.createdAt)}
                </small>
              </div>
              <div className="d-flex gap-1">
                <button className="btn btn-sm btn-outline-secondary" title="View file" onClick={() => viewFile(file)}>
                  <i className="bi bi-eye" />
                </button>
                {canDelete && (
                  <button className="btn btn-sm btn-outline-danger" title="Delete file" onClick={() => deleteFile(file)}>
                    <i className="bi bi-x-lg" />
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
      {preview && (
        <div className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-dark bg-opacity-75" style={{ zIndex: 1060 }}>
          <div className="bg-white rounded shadow p-3" style={{ width: 'min(95vw, 900px)', height: 'min(90vh, 700px)' }}>
            <div className="d-flex justify-content-between align-items-center mb-2">
              <strong className="text-truncate">{preview.file.fileName}</strong>
              <button
                className="btn btn-sm btn-outline-secondary"
                title="Close preview"
                onClick={() => {
                  URL.revokeObjectURL(preview.url);
                  setPreview(null);
                }}
              >
                <i className="bi bi-x-lg" />
              </button>
            </div>
            {preview.file.mimeType.startsWith('image/') ? (
              <img src={preview.url} alt={preview.file.fileName} className="w-100 h-100 object-fit-contain" />
            ) : (
              <iframe title={preview.file.fileName} src={preview.url} className="w-100 h-100 border-0" />
            )}
          </div>
        </div>
      )}
    </div>
  );
}