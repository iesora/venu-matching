import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface UpdateCreatorRequest {
  name?: string;
  description?: string;
  imageUrl?: string;
  email?: string;
  website?: string;
  phoneNumber?: string;
  socialMediaHandle?: string;
}

const updateCreator = async (body: {
  id: string;
  data: UpdateCreatorRequest;
}) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.patch(
    creatorURL + "/" + body.id,
    body.data,
    {
      headers,
    }
  );
  return response.data;
};

export const useAPIUpdateCreator = (
  mutationOptions?: UseMutationOptions<
    Creator,
    AxiosError,
    { id: string; data: UpdateCreatorRequest }
  >
) => {
  return useMutation<
    Creator,
    AxiosError,
    { id: string; data: UpdateCreatorRequest }
  >(updateCreator, mutationOptions);
};
