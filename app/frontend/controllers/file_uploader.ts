import { Controller } from '@hotwired/stimulus';
import axios, { AxiosResponse } from 'axios';
import S3Uploader from '@app/src/s3_uploader';
import deserialize from '@app/src/deserializer';
import { S3UploadSignature } from '@app/src/utils';

export default class extends Controller {
  async upload(
    path: string,
    file: File,
    uploadSignature: { scope: string; model: string }
  ): Promise<S3UploadSignature> {
    let response: AxiosResponse<any>;

    // 1. 署名情報の取得
    try {
      response = await axios.post(
        path,
        {
          content: {
            content_type: file.type,
            content_size: file.size,
            filename: file.name,
          },
          scope: uploadSignature.scope,
          model: uploadSignature.model,
        },
        {
          headers: {
            'X-CSRF-Token': (
              document.head.querySelector(
                '[name=csrf-token]'
              ) as HTMLMetaElement
            ).content,
          },
        }
      );
    } catch (error) {
      alert('アップロードに失敗しました。対応していないファイルです。');
      throw new Error('failed to get upload signature');
    }

    // 2. ダイレクトアップロード
    const s3 = new S3Uploader();

    try {
      await s3.upload(file, response.data.data.meta);
    } catch (error) {
      alert('アップロードに失敗しました。再度アップロードしてください。');
      throw new Error('failed to upload file to S3');
    }

    return deserialize(response.data);
  }
}
