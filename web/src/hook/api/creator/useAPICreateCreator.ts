import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface CreateCreatorRequest {
  name: string;
  description?: string;
  imageUrl?: string;
  email?: string;
  website?: string;
  phoneNumber?: string;
  socialMediaHandle?: string;
}

const createCreator = async (body: CreateCreatorRequest): Promise<Creator> => {
  const headers = await jsonHeader;
  const response = await axiosInstance.post(creatorURL, body, {
    headers,
  });
  return response.data;
};
export const useAPICreateCreator = (
  mutationOptions?: UseMutationOptions<
    Creator,
    AxiosError,
    CreateCreatorRequest
  >
) => {
  return useMutation<Creator, AxiosError, CreateCreatorRequest>(
    createCreator,
    mutationOptions
  );
};
